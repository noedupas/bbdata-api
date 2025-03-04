package ch.derlin.bbdata.output.security


import ch.derlin.bbdata.HiddenEnvironmentVariables
import ch.derlin.bbdata.Profiles
import ch.derlin.bbdata.actuators.CustomMetrics
import ch.derlin.bbdata.common.exceptions.BadApikeyException
import ch.derlin.bbdata.common.exceptions.ForbiddenException
import ch.derlin.bbdata.common.exceptions.UnauthorizedException
import ch.derlin.bbdata.output.api.apikeys.ApikeyRepository
import ch.derlin.bbdata.output.security.SecurityConstants.HEADER_TOKEN
import ch.derlin.bbdata.output.security.SecurityConstants.HEADER_USER
import ch.derlin.bbdata.output.security.SecurityConstants.SCOPE_WRITE
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Profile
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Component
import org.springframework.web.method.HandlerMethod
import org.springframework.web.servlet.HandlerInterceptor
import org.springframework.web.servlet.config.annotation.InterceptorRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer
import java.nio.charset.Charset
import java.util.*
import javax.annotation.PostConstruct
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse

// ========================

@Component
@Profile(Profiles.UNSECURED)
class DummyAuthInterceptor : HandlerInterceptor {

    private final val log = LoggerFactory.getLogger(DummyAuthInterceptor::class.java)

    @Value("\${${HiddenEnvironmentVariables.UNSECURED_USER}:1}")
    private val UNSECURED_BBUSER: Int = 1

    @PostConstruct
    fun postConstruct() {
        log.warn("${Profiles.UNSECURED} is ON !!! Automatically login as User #$UNSECURED_BBUSER")
    }

    override fun preHandle(request: HttpServletRequest, response: HttpServletResponse, handler: Any): Boolean {
        // for tests: allow the header "bbuser" (but not in Basic format !)
        request.setAttribute(HEADER_USER, request.getHeader(HEADER_USER) ?: UNSECURED_BBUSER.toString())
        return true
    }
}

@Configuration
@Profile(Profiles.UNSECURED)
class DummyWebMvcConfiguration : WebMvcConfigurer {

    @Autowired
    lateinit var authInterceptor: DummyAuthInterceptor

    override fun addInterceptors(registry: InterceptorRegistry) {
        registry.addInterceptor(authInterceptor)
    }
}

// ========================

@Component
@Profile(Profiles.NOT_UNSECURED)
class AuthInterceptor(
        private val apikeyRepository: ApikeyRepository,
        private val customMetrics: CustomMetrics) : HandlerInterceptor {

    private val log: Logger = LoggerFactory.getLogger(AuthInterceptor::class.java)

    override fun preHandle(request: HttpServletRequest, response: HttpServletResponse, handler: Any): Boolean {

        if (handler !is HandlerMethod) return true // static resources, do nothing

        // allow options method to support CORS requests
        if (request.method.equals("options", ignoreCase = true)) {
            response.status = HttpStatus.OK.value()
            return true
        }

        // allow non-bbdata endpoints, such as doc
        if (!handler.beanType.name.contains("bbdata")) {
            return true
        }

        // get security annotation and scope
        val securityAnnotation = handler.method.getAnnotation(Protected::class.java)

        if (securityAnnotation == null) {
            // "free access" endpoints, do nothing
            return true
        }
        val writeRequired = securityAnnotation.value.contains(SCOPE_WRITE)

        // extract userId and token into request attributes
        extractAuth(request)
        val bbuser = request.getAttribute(HEADER_USER) as String
        val bbtoken = request.getAttribute(HEADER_TOKEN) as String

        // missing one of the two headers...
        if (bbuser == "" || bbtoken == "") {
            throw UnauthorizedException("This resource is protected. "
                    + "Missing authorization headers: ${HEADER_USER}=<user_id:int>, ${HEADER_TOKEN}=<token:string>")
        }

        bbuser.toIntOrNull()?.let { userId ->
            // check valid tokens
            val apikey = apikeyRepository.findValid(userId, bbtoken).orElseThrow {
                customMetrics.authFailed(userId)
                log.info("wrong apikey for userId=$userId token='$bbtoken'")
                BadApikeyException("Access denied for user $userId : bad apikey")
            }
            // check if write access is necessary
            if (apikey.readOnly && writeRequired) {
                // check write permissions
                throw ForbiddenException("Access denied for user $userId: this apikey is read-only")
            }
            // every checks passed !
            return true
        }

        // bbuser is not an int
        throw BadApikeyException("Wrong header $HEADER_USER=$bbuser. Should be an integer")

    }


    companion object {

        fun extractAuth(request: HttpServletRequest) {
            // Basic Authorization header has the format: "Basic <base64-encoded user:pass>"
            val auth = request.getHeader("Authorization")
            if (auth != null && auth.startsWith("Basic")) {
                try {
                    val decoded = String(
                            Base64.getDecoder().decode(auth.replaceFirst("Basic ", "").toByteArray()),
                            charset = UTF_8_CHARSET
                    ).split(":")

                    if (decoded.size == 2) {
                        request.setAttribute(HEADER_USER, decoded[0])
                        request.setAttribute(HEADER_TOKEN, decoded[1])
                        return
                    }
                } catch (ex: Exception) {
                    throw BadApikeyException("The Basic Authentication provided (Base64) is invalid.")
                }
            }

            // If not working, extract from the headers
            request.setAttribute(HEADER_USER, request.getHeader(HEADER_USER) ?: "")
            request.setAttribute(HEADER_TOKEN, request.getHeader(HEADER_TOKEN) ?: "")
        }

        val UTF_8_CHARSET: Charset = Charset.forName("utf-8")
    }

}

@Configuration
@Profile(Profiles.NOT_UNSECURED)
class WebMvcConfiguration : WebMvcConfigurer {

    @Autowired
    lateinit var authInterceptor: AuthInterceptor

    override fun addInterceptors(registry: InterceptorRegistry) {
        registry.addInterceptor(authInterceptor)
    }
}