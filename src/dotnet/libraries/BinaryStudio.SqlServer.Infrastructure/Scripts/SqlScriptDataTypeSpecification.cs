using System;
using System.Collections.Generic;
using System.Text;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDataTypeSpecification))]
    internal sealed class SqlScriptDataTypeSpecification : SqlScriptCodeObject<SqlDataTypeSpecification>,ISqlTypeSpecifier
        {
        private const Int32 DEFAULT_FLOAT_PRECISION   = 53;
        private const Int32 DEFAULT_DECIMAL_PRECISION = 18;
        private const Int32 DEFAULT_DECIMAL_SCALE     = 0;
        private const Int32 DEFAULT_TIME_SCALE        = 7;

        public Int32? Precision { get; }
        public Int32? Scale { get; }
        public Int32? Length { get; }
        [UsedImplicitly][Field] public Boolean IsCursor { get; }
        [UsedImplicitly][Field] public Boolean IsMaximum { get; }
        [UsedImplicitly][Field] public SqlScriptDataType DataType { get; }
        [UsedImplicitly][Field] public SqlObjectIdentifier XmlSchemaCollection { get; }
        private SqlDataType DataTypeKind { get; }

        #region ctor{IServiceProvider,SqlDataTypeSpecification}
        public SqlScriptDataTypeSpecification(IServiceProvider context,SqlDataTypeSpecification source)
            : base(context,source)
            {
            if (BuiltInTypes.TryGetValue(DataType.ObjectIdentifier.ObjectName.Value,out var type)) {
                DataTypeKind = type;
                switch (type) {
                    case SqlDataType.Time:
                    case SqlDataType.DateTime2:
                    case SqlDataType.DateTimeOffset:
                        Scale = source.Argument1;
                        break;
                    case SqlDataType.Float:
                    case SqlDataType.Decimal:
                    case SqlDataType.Numeric:
                        Precision = source.Argument1;
                        Scale     = source.Argument2;
                        break;
                    case SqlDataType.VarBinary:
                    case SqlDataType.VarChar:
                    case SqlDataType.Binary:
                    case SqlDataType.Char:
                        Length = source.Argument1;
                        break;
                    case SqlDataType.NVarChar:
                    case SqlDataType.NChar:
                    case SqlDataType.NText:
                        Length = source.Argument1;
                        break;
                    }
                }
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString() {
            var r = new StringBuilder();
            if (DataTypeKind != SqlDataType.None) {
                switch (DataTypeKind) {
                    case SqlDataType.Variant:
                        r.Append("sql_variant");
                        break;
                    default:
                        r.Append(DataTypeKind.ToString().ToLowerInvariant());
                        break;
                    }
                switch (DataTypeKind) {
                    case SqlDataType.Time:
                    case SqlDataType.DateTime2:
                    case SqlDataType.DateTimeOffset:
                        if ((Scale != DEFAULT_TIME_SCALE) && (Scale != null)) {
                            r.AppendFormat("({0})",Scale.Value);
                            }
                        break;
                    case SqlDataType.Float:
                        if ((Precision != DEFAULT_FLOAT_PRECISION) && (Precision != null)) {
                            r.AppendFormat("({0})",Precision);
                            }
                        break;
                    case SqlDataType.Decimal:
                    case SqlDataType.Numeric:
                        if (Scale == DEFAULT_DECIMAL_SCALE) {
                            if (Precision != DEFAULT_DECIMAL_PRECISION)
                                {
                                r.AppendFormat("({0})",Precision);
                                }
                            }
                        else
                            {
                            r.AppendFormat("({0},{1})",Precision,Scale);
                            }
                        break;
                    case SqlDataType.VarBinary:
                    case SqlDataType.VarChar:
                    case SqlDataType.NVarChar:
                        if (IsMaximum || (Length == -1)) {
                            r.Append("(max)");
                            }
                        else
                            {
                            r.Append($"({Length})");
                            }
                        break;
                    case SqlDataType.NChar:
                    case SqlDataType.Char:
                    case SqlDataType.Binary:
                        r.Append($"({Length})");
                        break;
                    }
                }
            return r.ToString();
            }
        #endregion

        private static readonly IDictionary<String,SqlDataType> BuiltInTypes = new Dictionary<String,SqlDataType>{
            {"bigint"          ,SqlDataType.BigInt          },
            {"binary"          ,SqlDataType.Binary          },
            {"bit"             ,SqlDataType.Bit             },
            {"char"            ,SqlDataType.Char            },
            {"date"            ,SqlDataType.Date            },
            {"datetime"        ,SqlDataType.DateTime        },
            {"datetime2"       ,SqlDataType.DateTime2       },
            {"datetimeoffset"  ,SqlDataType.DateTimeOffset  },
            {"decimal"         ,SqlDataType.Decimal         },
            {"float"           ,SqlDataType.Float           },
            {"geography"       ,SqlDataType.Geography       },
            {"geometry"        ,SqlDataType.Geometry        },
            {"hierarchyid"     ,SqlDataType.Hierarchy       },
            {"image"           ,SqlDataType.Image           },
            {"int"             ,SqlDataType.Int             },
            {"json"            ,SqlDataType.Json            },
            {"money"           ,SqlDataType.Money           },
            {"nchar"           ,SqlDataType.NChar           },
            {"ntext"           ,SqlDataType.NText           },
            {"numeric"         ,SqlDataType.Numeric         },
            {"nvarchar"        ,SqlDataType.NVarChar        },
            {"real"            ,SqlDataType.Real            },
            {"rowversion"      ,SqlDataType.Rowversion      },
            {"smalldatetime"   ,SqlDataType.SmallDateTime   },
            {"smallint"        ,SqlDataType.SmallInt        },
            {"smallmoney"      ,SqlDataType.SmallMoney      },
            {"sql_variant"     ,SqlDataType.Variant         },
            {"text"            ,SqlDataType.Text            },
            {"time"            ,SqlDataType.Time            },
            {"timestamp"       ,SqlDataType.Timestamp       },
            {"tinyint"         ,SqlDataType.TinyInt         },
            {"uniqueidentifier",SqlDataType.UniqueIdentifier},
            {"varbinary"       ,SqlDataType.VarBinary       },
            {"varchar"         ,SqlDataType.VarChar         },
            {"vector"          ,SqlDataType.Vector          },
            {"xml"             ,SqlDataType.Xml             },
            };
        }
    }