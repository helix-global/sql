using System;
using System.Collections.Generic;
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
        SqlDataType ISqlTypeSpecifier.Type { get { return DataTypeKind; }}

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
            return ToString(DEFTypeSpecifierFormatter.Instance);
            }
        #endregion
        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public String ToString(ISqlObjectFormatter<ISqlTypeSpecifier> Formater) {
            Formater.WriteTo(Context,this,out var r);
            return r;
            }
        #endregion

        private static readonly IDictionary<String,SqlDataType> BuiltInTypes = new Dictionary<String,SqlDataType>(StringComparer.OrdinalIgnoreCase){
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