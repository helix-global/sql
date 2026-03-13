using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public abstract class SqlType
        {
        public abstract String Name { get; }
        public abstract Boolean IsBuiltIn { get; }
        public static readonly SqlType BigInt           = new SqlBuiltInType(SqlDataType.BigInt);
        public static readonly SqlType Int              = new SqlBuiltInType(SqlDataType.Int);
        public static readonly SqlType SmallInt         = new SqlBuiltInType(SqlDataType.SmallInt);
        public static readonly SqlType TinyInt          = new SqlBuiltInType(SqlDataType.TinyInt);
        public static readonly SqlType Bit              = new SqlBuiltInType(SqlDataType.Bit);
        public static readonly SqlType Decimal          = new SqlBuiltInType(SqlDataType.Decimal);
        public static readonly SqlType Numeric          = new SqlBuiltInType(SqlDataType.Numeric);
        public static readonly SqlType Money            = new SqlBuiltInType(SqlDataType.Money);
        public static readonly SqlType SmallMoney       = new SqlBuiltInType(SqlDataType.SmallMoney);
        public static readonly SqlType Float            = new SqlBuiltInType(SqlDataType.Float);
        public static readonly SqlType Real             = new SqlBuiltInType(SqlDataType.Real);
        public static readonly SqlType DateTime         = new SqlBuiltInType(SqlDataType.DateTime);
        public static readonly SqlType SmallDateTime    = new SqlBuiltInType(SqlDataType.SmallDateTime);
        public static readonly SqlType Char             = new SqlBuiltInType(SqlDataType.Char);
        public static readonly SqlType VarChar          = new SqlBuiltInType(SqlDataType.VarChar);
        public static readonly SqlType Text             = new SqlBuiltInType(SqlDataType.Text);
        public static readonly SqlType NChar            = new SqlBuiltInType(SqlDataType.NChar);
        public static readonly SqlType NVarChar         = new SqlBuiltInType(SqlDataType.NVarChar);
        public static readonly SqlType NText            = new SqlBuiltInType(SqlDataType.NText);
        public static readonly SqlType Binary           = new SqlBuiltInType(SqlDataType.Binary);
        public static readonly SqlType VarBinary        = new SqlBuiltInType(SqlDataType.VarBinary);
        public static readonly SqlType Image            = new SqlBuiltInType(SqlDataType.Image);
        public static readonly SqlType Cursor           = new SqlBuiltInType(SqlDataType.Cursor);
        public static readonly SqlType Variant          = new SqlBuiltInType(SqlDataType.Variant);
        public static readonly SqlType Table            = new SqlBuiltInType(SqlDataType.Table);
        public static readonly SqlType Timestamp        = new SqlBuiltInType(SqlDataType.Timestamp);
        public static readonly SqlType UniqueIdentifier = new SqlBuiltInType(SqlDataType.UniqueIdentifier);
        public static readonly SqlType Xml              = new SqlBuiltInType(SqlDataType.Xml);
        public static readonly SqlType Date             = new SqlBuiltInType(SqlDataType.Date);
        public static readonly SqlType Time             = new SqlBuiltInType(SqlDataType.Time);
        public static readonly SqlType DateTime2        = new SqlBuiltInType(SqlDataType.DateTime2);
        public static readonly SqlType DateTimeOffset   = new SqlBuiltInType(SqlDataType.DateTimeOffset);
        public static readonly SqlType Rowversion       = new SqlBuiltInType(SqlDataType.Rowversion);
        public static readonly SqlType Json             = new SqlBuiltInType(SqlDataType.Json);
        public static readonly SqlType Vector           = new SqlBuiltInType(SqlDataType.Vector);
        }
    }