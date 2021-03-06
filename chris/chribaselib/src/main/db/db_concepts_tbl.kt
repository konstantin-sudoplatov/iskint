package db

import basemain.Cid
import basemain.Clid
import basemain.Ver
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.sql.Connection
import java.sql.ResultSet
import java.sql.SQLException

/** 
 *      Serialized dynamic concept data. 
 */
data class SerializedConceptData(
    var cid: Cid = 0,
    var ver: Ver = 0,
    var clid: Clid = 0,
    var stable: ByteBuffer? = null,
    var transient: ByteBuffer? = null
)

/**
 *          Dynamic concepts.
 *  Table: concepts
 *  Fields:
 *      "cid",          // concept identifier
 *      "ver",          // version of the concept
 *      "clid",         // class identifier
 *      "stable",       // data responsible for logic and behavior
 *      "transient"     // changeable data like usage statistics
 */
class ConceptsTbl(conn: Connection, private val schema: String, private val tableName: String) {

    /**
     *      Insert record to the concepts table.
     *  @param cid cid
     *  @param ver version
     *  @param clid class identifier
     *  @param stable serialized stable data of the concept
     *  @param transient serialized transient data of the concept
     */
    fun insertConcept(cid: Cid, ver: Ver, clid: Clid, stable: ByteArray?, transient: ByteArray?) {
        insertConceptStmt_.setInt(1, cid)
        insertConceptStmt_.setShort(2, ver)
        insertConceptStmt_.setShort(3, clid)
        insertConceptStmt_.setBytes(4, stable)
        insertConceptStmt_.setBytes(5, transient)

        insertConceptStmt_.executeUpdate()
    }

    /**
     *      Delete record from the concepts table.
     *  @param cid cid
     *  @param ver version
     */
    fun deleteConcept(cid: Cid, ver: Ver) {
        deleteConceptStmt_.setInt(1, cid)
        deleteConceptStmt_.setShort(2, ver)

        deleteConceptStmt_.executeUpdate()
    }

    /**
     *      Get record from the concepts table.
     *  @param cid cid
     *  @param ver version
     *  @return SerializedConceptData object, that contains all the fields of the record or null if not found
     */
    fun getConcept(cid: Cid, ver: Ver): SerializedConceptData? {
        getConceptStmt_.setInt(1, cid)
        getConceptStmt_.setShort(2, ver)

        val rs: ResultSet = getConceptStmt_.executeQuery()
        return if   // isn't there such record?
                    (!rs.next())
            rs.use{ null }
        else
            rs.use{
                val sCD = SerializedConceptData(
                    cid = cid,
                    ver = ver,
                    clid = it.getShort("clid"),
                    stable = null,
                    transient = null
                )
                val stable = it.getBytes("stable")
                if(stable != null)
                    sCD.stable = ByteBuffer.wrap(stable).order(ByteOrder.nativeOrder())
                val transient = it.getBytes("transient")
                if(transient != null)
                    sCD.transient = ByteBuffer.wrap(transient).order(ByteOrder.nativeOrder())

                sCD
            }
    }

    /**
     *      Update record in the concepts table.
     *  @param cid cid
     *  @param ver version
     *  @param clid class identifier
     *  @param stable serialized stable data of the concept
     *  @param transient serialized transient data of the concept
     */
    fun updateConcept(cid: Cid, ver: Ver, clid: Clid, stable: ByteArray?, transient: ByteArray?) {
        updateConceptStmt_.setShort(1, clid)
        updateConceptStmt_.setBytes(2, stable)
        updateConceptStmt_.setBytes(3, transient)
        updateConceptStmt_.setInt(4, cid)
        updateConceptStmt_.setShort(5, ver)

        updateConceptStmt_.executeUpdate()
    }

    /**
     *      Get all versions of given concept.
     *  @param cid cid
     *  @return array of versions or null if no record with this cid is found
     */
    fun getConceptVersions(cid: Cid): ShortArray? {
        getConceptVersionsStmt_.setInt(1, cid)

        val rs = getConceptVersionsStmt_.executeQuery()
        return if  // isn't there a record?
                   (!rs.next())
            rs.use{ null }
        else
            rs.use { it.getArray("ver") }.array as ShortArray    // not sure, needs debugging
    }

    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%
    //
    //                               Private
    //
    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%

    //---%%%---%%%---%%%---%%%--- private data ---%%%---%%%---%%%---%%%---%%%---%%%

    /** Prepared statement: insert new concept into table. */
    private val insertConceptStmt_ =
        try {
            conn.prepareStatement("""insert into "$schema"."$tableName" (cid, ver, clid, stable, transient) values(?, ?, ?, ?, ?)""")
        } catch (e: SQLException) {
            throw IllegalStateException(e.message)
        }

    /** Prepared statement: remove from the table concept with given cid+ver. */
    private val deleteConceptStmt_ =
        try {
            conn.prepareStatement("""delete from "$schema"."$tableName" where cid = ? and ver = ?""")
        } catch (e: SQLException) {
            throw IllegalStateException(e.message)
        }

    /** Prepared statement: get concept by cid+ver. */
    private val getConceptStmt_ =
        try {
            conn.prepareStatement("""select clid, stable, transient from "$schema"."$tableName" where cid = ? and ver = ?""")
        } catch (e: SQLException) {
            throw IllegalStateException(e.message)
        }

    /** Prepared statement: update concept with given cid+ver. */
    private val updateConceptStmt_ =
        try {
            conn.prepareStatement("""update "$schema"."$tableName" set clid = ?, stable = ?, transient = ? where cid = ? and ver = ?""")
        } catch (e: SQLException) {
            throw IllegalStateException(e.message)
        }

    /** Prepared statement: find all versions of a concept with given cid. */
    private val getConceptVersionsStmt_ =
        try {
            conn.prepareStatement("""select ver from "$schema"."$tableName" where cid = ? order by ver""")
        } catch (e: SQLException) {
            throw IllegalStateException(e.message)
        }
}
