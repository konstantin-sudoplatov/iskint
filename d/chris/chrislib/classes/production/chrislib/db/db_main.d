module db.db_main;
import std.exception;
import std.string, std.conv, std.format;
version(unittest) import std.stdio;

import derelict.pq.pq;

import common_tools;

/// Credentials for the DB. Be carefull not to use named enums in writeln or format functions without implicit cast to
/// string. You'll get strange results! While cast(string)DbCreds.password gives out "chris", to!string(DbCreds.password) will
/// produce "user"!!! D is sometimes weird.
enum DbCreds {
    user = "chris",
    password = "chris",
    dbname = "chris"
}

//---***---***---***---***---***--- data ---***---***---***---***---***--


/**
        Static constructor
*/
shared static this() {
    // Add shared library /usr/lib/x_86-64-linux-gnu/libpq.so
//    DerelictPQ.load();
}

//---***---***---***---***---***--- functions ---***---***---***---***---***--

/// Connect to the database, set up the connectionPtr_ field.
PGconn* connectToDb() {

    string s = format!`user='%s' password='%s' dbname='%s'`(
        cast(string)DbCreds.user,
        cast(string)DbCreds.password,
        cast(string)DbCreds.dbname
    );
    PGconn* conn = PQconnectdb(s.toStringz);
    if(PQstatus(conn) != CONNECTION_OK)
            enforce(false, to!string(PQerrorMessage(conn)));
    return conn;
}

/// Finish work with the data base.
void disconnectFromDb(PGconn* conn) {
    PQfinish(conn);
}

//---***---***---***---***---***--- types ---***---***---***---***---***---***
/// Concept version
alias Cvr = ushort;


/**
        Concept version control struct. BR
    It contains a raw version field, which is the part of each concept. Zero value of that field is quite legal and it
    means that the concept is of the _min_ver_ version, the oldest valid version that cannot be removed yet.
*/
shared synchronized class ConceptVersion {

    /// The newest availabale version to use. This is the latest version commited by the tutor. If the _cur_ver_ rolled over the
    /// Cvr.max and became the lesser number than all other versions, it stil must not reach the _stale_ver_, or an assertion
    /// exception will be thrown.
    private static Cvr _cur_ver_;

    /// Minimal currently used version. If a concept has version 0 it means this version. All versions older than that
    /// they are stale and may be removed.
    private static Cvr _min_ver_;

    /// Minimum stale version. Stale versions are less than _min_ver_ and so should be removed.
    private static Cvr _stale_ver_;
}

/// All we need to control the params table.
struct TableParams {

    @disable this();
    this(PGconn* conn) {
        conn_ = conn;
    }

    /// Name of the params table
    enum tableName = "params";

    /// Table fields
    enum {
        name = "name",      // parameter name
        value = "value",    // parameter value
        description = "description"     // description of the parameter
    }

    /// Prepared statement's names
    enum {
        getParam_stmt = "getParam_stmt",
        setParam_stmt = "setParam_stmt"
    }

    /**
            Get parameter by name. The record in database must exist, else an assertion is thrown.
        Parameters:
            name = name of the parameter
        Returns: value of the parameter as a string, null is possible since the field can be null.
    */
    string getParam(string name) {
        PGresult* res;
        char** paramValues = [cast(char*)name.toStringz].ptr;
        res = PQexecPrepared(
            conn_,
            getParam_stmt,
            1,      // nParams
            paramValues,
            null,
            null,
            0       // result as a string
        );
        assert(PQresultStatus(res) == PGRES_TUPLES_OK, to!string(PQerrorMessage(conn_)));
        assert(PQntuples(res) == 1, format!"Found %s records for parameter: %s"(PQntuples(res), name));
        scope(exit) PQclear(res);

        char* pc = cast(char*)PQgetvalue(res, 0, 0);
        if      // not empty string?
                (*pc != 0)
            return to!string(pc);
        else //no: make difference betwee the null and empty string
            if(PQgetisnull(res, 0, 0))
                return null;
            else
                return "";
    }

    /**
            Set parameter's value. Setting the null value is legal. Exactly one record must be updated, else an assertion
        is thrown.
        Parameters:
            name = name of the parameter
            value = value to set, can be null
    */
    void setParam(string name, string value) {
        PGresult* res;

        char* pcValue;
        pcValue = value is null? null: cast(char*)value.toStringz;
        char** paramValues = [cast(char*)name.toStringz, pcValue].ptr;
        res = PQexecPrepared(
            conn_,
            setParam_stmt,
            2,      // nParams
            paramValues,
            null,
            null,
            0       // result as a string
        );
        assert(PQresultStatus(res) == PGRES_COMMAND_OK, to!string(PQerrorMessage(conn_)));
        string sTuplesAffected = to!string(PQcmdTuples(res));
        assert(sTuplesAffected == "1", format!"Updated %s records for parameter: %s"(sTuplesAffected, name));
        PQclear(res);
    }

    /// Prepare all statements, whose names a present in the enum
    void prepare() {
        PGresult* res;

        res = PQprepare(
            conn_,
            getParam_stmt,
            format!"select %s from %s where %s=$1"(value, tableName, name).toStringz,
            0,
            null
        );
        assert(PQresultStatus(res) == PGRES_COMMAND_OK, to!string(PQerrorMessage(conn_)));
        PQclear(res);

        res = PQprepare(
            conn_,
            setParam_stmt,
            format!"update %s set %s=$2 where %s=$1"(tableName, value, name).toStringz,
            0,
            null
        );
        assert(PQresultStatus(res) == PGRES_COMMAND_OK, to!string(PQerrorMessage(conn_)));
        PQclear(res);
    }

    private PGconn* conn_;      /// Connection
}

unittest {
    PGconn* conn = connectToDb;
    auto tp = TableParams(conn);

    //TableParams.getParam("_cur_ver_");
    tp.prepare;
    string par = tp.getParam("_stale_ver_");
    tp.setParam("_stale_ver_", par);
    assert(tp.getParam("_stale_ver_") == par);
    disconnectFromDb(conn);
}

//===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@
//
//                                  Private
//
//===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@

//---%%%---%%%---%%%---%%%---%%% data ---%%%---%%%---%%%---%%%---%%%---%%%

//---%%%---%%%---%%%---%%%---%%% functions ---%%%---%%%---%%%---%%%---%%%---%%%--

//---%%%---%%%---%%%---%%%---%%% types ---%%%---%%%---%%%---%%%---%%%---%%%--