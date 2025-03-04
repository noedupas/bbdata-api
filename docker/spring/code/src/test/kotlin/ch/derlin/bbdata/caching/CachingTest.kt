package ch.derlin.bbdata.caching

import ch.derlin.bbdata.*
import ch.derlin.bbdata.input.InputApiTest
import com.jayway.jsonpath.JsonPath
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.MethodOrderer
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestMethodOrder
import org.junit.jupiter.api.extension.ExtendWith
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.web.client.TestRestTemplate
import org.springframework.cache.CacheManager
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.context.junit.jupiter.SpringExtension
import kotlin.random.Random


/**
 * date: 05.08.20
 * @author Lucy Linder <lucy.derlin@gmail.com>
 */
@ExtendWith(SpringExtension::class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = [UNSECURED_REGULAR, NO_KAFKA, "spring.cache.type=simple"])
@ActiveProfiles(Profiles.UNSECURED)
@TestMethodOrder(MethodOrderer.Alphanumeric::class)
class CachingTest {

    @Autowired
    private lateinit var restTemplate: TestRestTemplate

    @Autowired
    private lateinit var cacheManager: CacheManager


    companion object {
        var OBJ_ID = -1

        // dynamically create tokens
        var tokenIds = mutableListOf<Int>()
        var tokenStrings = mutableListOf<String>()
    }

    @Test
    fun `0-1 setup object`() {
        // create object
        val resp = restTemplate.putWithBody("/objects",
                """{"name": "new ${Random.nextInt()}", "owner": $REGULAR_USER_ID, "unitSymbol": "lx"}""")
        assertEquals(HttpStatus.OK, resp.statusCode)
        OBJ_ID = JsonPath.parse(resp.body).read<Int>("$.id")
        // create tokens
        createToken()
        createToken()
    }

    @Test
    fun `1-0 test cacheable`() {
        // add two entries to the cache
        tokenStrings.forEach { submitAndCheckCache(it) }
    }

    @Test
    fun `1-1 test auto cache evict`() {
        // delete token 0
        val resp = restTemplate.deleteQueryString("/objects/$OBJ_ID/tokens/${tokenIds[0]}")
        assertEquals(HttpStatus.OK, resp.statusCode)

        // check cache
        assertNull(cacheEntry(tokenStrings[0]))
        assertNotNull(cacheEntry(tokenStrings[1])) // this one should not have changed

        // check input api
        val resp2 = submitMeasure(tokenStrings[0])
        assertNotEquals(HttpStatus.OK, resp2.statusCode)
    }

    @Test
    fun `1-2 test auto cache evict all`() {
        // add two values in the cache, for different objects
        submitAndCheckCache(tokenStrings[1])
        // use another object
        val existing_obj = InputApiTest.OBJ
        submitAndCheckCache(TOKEN(existing_obj), existing_obj)

        // disable one object (should evict all entries in the cache)
        val resp = restTemplate.postQueryString("/objects/$OBJ_ID/disable")
        assertEquals(HttpStatus.OK, resp.statusCode)

        // check cache
        assertNull(cacheEntry(TOKEN(existing_obj), InputApiTest.OBJ))
        assertNull(cacheEntry(tokenStrings[1]))

        // check input api (the token was wiped on disable)
        val resp2 = submitMeasure(tokenStrings[1])
        assertNotEquals(HttpStatus.OK, resp2.statusCode)
    }

    // -----------

    private fun createToken() {
        val response = restTemplate.putQueryString("/objects/$OBJ_ID/tokens")
        assertEquals(HttpStatus.OK, response.statusCode)
        val json = JsonPath.parse(response.body)
        tokenIds.add(json.read<Int>("$.id"))
        tokenStrings.add(json.read<String>("$.token"))
    }

    private fun submitMeasure(token: String, objectId: Int = OBJ_ID): ResponseEntity<String> =
            restTemplate.postWithBody(InputApiTest.URL, InputApiTest.getMeasureBody(objectId = objectId, token = token))

    private fun submitAndCheckCache(token: String, objectId: Int = OBJ_ID) {
        // post a measure
        val resp = submitMeasure(token, objectId)
        assertEquals(HttpStatus.OK, resp.statusCode)

        // assert value in the cache
        assertTrue(cacheManager.cacheNames.contains(Constants.META_CACHE))
        assertNotNull(cacheEntry(token, objectId))
    }

    private fun cacheEntry(token: String, oid: Int = OBJ_ID) =
            cacheManager.getCache(Constants.META_CACHE)?.get("$oid:$token")
}