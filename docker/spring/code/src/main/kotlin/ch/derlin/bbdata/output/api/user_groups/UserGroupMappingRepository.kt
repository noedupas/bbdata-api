package ch.derlin.bbdata.output.api.user_groups

import ch.derlin.bbdata.output.security.SecurityConstants.SUPERADMIN_GROUP
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository
import org.springframework.transaction.annotation.Transactional

/**
 * date: 06.12.19
 * @author Lucy Linder <lucy.derlin@gmail.com>
 */

@Repository
interface UserGroupMappingRepository : JpaRepository<UsergroupMapping, UserUgrpMappingId> {
    @Transactional
    fun deleteByGroupId(groupId: Int)

    fun getByUserId(userId: Int): List<UsergroupMapping>

    @Query("SELECT CASE WHEN count(u) > 0 THEN true ELSE false END " +
            "FROM UsergroupMapping u WHERE u.userId = :userId AND u.groupId = $SUPERADMIN_GROUP AND u.isAdmin = true")
    fun isSuperAdmin(userId: Int): Boolean

}