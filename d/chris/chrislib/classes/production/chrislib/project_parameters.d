module project_parameters;

/// Concept identifier type
alias Cid = uint;

/// Concept version type
alias Cvr = ushort;

/// Static cid range is from 1 to MAX_STATIC_CID;
enum MIN_STATIC_CID = Cid(1);
enum MAX_STATIC_CID = Cid(1_000_000);
enum MIN_DYNAMIC_CID = Cid(2_000_000);
enum MAX_DINAMIC_CID = Cid.max;
static assert(MIN_DYNAMIC_CID > MAX_STATIC_CID);
enum MIN_TEMP_CID = MAX_STATIC_CID + 1;
enum MAX_TEMP_CID = MIN_DYNAMIC_CID - 1;
static assert(MAX_TEMP_CID >= MIN_TEMP_CID);
