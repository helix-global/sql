using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public enum SqlDataType
        {
        None,
        Image            =  34,
        Text             =  35,
        UniqueIdentifier =  36,
        Date             =  40,
        Time             =  41,
        DateTime2        =  42,
        DateTimeOffset   =  43,
        TinyInt          =  48,
        SmallInt         =  52,
        Int              =  56,
        SmallDateTime    =  58,
        Real             =  59,
        Money            =  60,
        DateTime         =  61,
        Float            =  62,
        Variant          =  98,
        NText            =  99,
        Bit              = 104,
        Decimal          = 106,
        Numeric          = 108,
        SmallMoney       = 122,
        BigInt           = 127,
        VarBinary        = 165,
        VarChar          = 167,
        Binary           = 173,
        Char             = 175,
        Timestamp        = 189,
        Rowversion       = 189,
        NVarChar         = 231,
        NChar            = 239,
        Geometry         = 240,
        Geography        = 240,
        Hierarchy        = 240,
        Xml              = 241,
        Json             = 8001,
        Table            = 8002,
        Cursor           = 8003,
        Vector           = 8004,
        UserDefined      = 8005
        }
    }
