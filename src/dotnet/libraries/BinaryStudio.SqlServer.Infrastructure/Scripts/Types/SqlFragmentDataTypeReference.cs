using System;
using System.Linq;
using System.Text;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class SqlFragmentDataTypeReference<T> : SqlFragmentObject<T>,ISqlFragmentDataTypeReference
        where T : DataTypeReference
        {
        [UsedImplicitly][Field] public SqlIdentifier Name { get; }

        #region ctor{IServiceProvider,T}
        protected SqlFragmentDataTypeReference(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Name.ToString();
            }
        #endregion
        }

    /// <summary>
    /// Represents built-in data types.
    /// </summary>
    [UsedImplicitly]
    [SqlScriptObject(typeof(SqlDataTypeReference))]
    internal sealed class SqlFragmentDataTypeReference : SqlFragmentParameterizedDataTypeReference<SqlDataTypeReference>
        {
        private const Int32 DEFAULT_FLOAT_PRECISION   = 53;
        private const Int32 DEFAULT_DECIMAL_PRECISION = 18;
        private const Int32 DEFAULT_DECIMAL_SCALE     = 0;
        private const Int32 DEFAULT_TIME_SCALE        = 7;

        public Int32? Precision { get; }
        public Int32? Scale { get; }
        public Int32? Length { get; }
        public SqlDataType DataType { get; }
        public Boolean IsMaximum { get; }

        #region ctor{IServiceProvider,SqlDataTypeReference}
        public SqlFragmentDataTypeReference(IServiceProvider context,SqlDataTypeReference source)
            : base(context,source)
            {
            switch (source.SqlDataTypeOption) {
                case SqlDataTypeOption.None            : { DataType=SqlDataType.None;             } break;
                case SqlDataTypeOption.BigInt          : { DataType=SqlDataType.BigInt;           } break;
                case SqlDataTypeOption.Int             : { DataType=SqlDataType.Int;              } break;
                case SqlDataTypeOption.SmallInt        : { DataType=SqlDataType.SmallInt;         } break;
                case SqlDataTypeOption.TinyInt         : { DataType=SqlDataType.TinyInt;          } break;
                case SqlDataTypeOption.Bit             : { DataType=SqlDataType.Bit;              } break;
                case SqlDataTypeOption.Decimal         : { DataType=SqlDataType.Decimal;          } break;
                case SqlDataTypeOption.Numeric         : { DataType=SqlDataType.Numeric;          } break;
                case SqlDataTypeOption.Money           : { DataType=SqlDataType.Money;            } break;
                case SqlDataTypeOption.SmallMoney      : { DataType=SqlDataType.SmallMoney;       } break;
                case SqlDataTypeOption.Float           : { DataType=SqlDataType.Float;            } break;
                case SqlDataTypeOption.Real            : { DataType=SqlDataType.Real;             } break;
                case SqlDataTypeOption.DateTime        : { DataType=SqlDataType.DateTime;         } break;
                case SqlDataTypeOption.SmallDateTime   : { DataType=SqlDataType.SmallDateTime;    } break;
                case SqlDataTypeOption.Char            : { DataType=SqlDataType.Char;             } break;
                case SqlDataTypeOption.VarChar         : { DataType=SqlDataType.VarChar;          } break;
                case SqlDataTypeOption.Text            : { DataType=SqlDataType.Text;             } break;
                case SqlDataTypeOption.NChar           : { DataType=SqlDataType.NChar;            } break;
                case SqlDataTypeOption.NVarChar        : { DataType=SqlDataType.NVarChar;         } break;
                case SqlDataTypeOption.NText           : { DataType=SqlDataType.NText;            } break;
                case SqlDataTypeOption.Binary          : { DataType=SqlDataType.Binary;           } break;
                case SqlDataTypeOption.VarBinary       : { DataType=SqlDataType.VarBinary;        } break;
                case SqlDataTypeOption.Image           : { DataType=SqlDataType.Image;            } break;
                case SqlDataTypeOption.Cursor          : { DataType=SqlDataType.Cursor;           } break;
                case SqlDataTypeOption.Sql_Variant     : { DataType=SqlDataType.Variant;          } break;
                case SqlDataTypeOption.Table           : { DataType=SqlDataType.Table;            } break;
                case SqlDataTypeOption.Timestamp       : { DataType=SqlDataType.Timestamp;        } break;
                case SqlDataTypeOption.UniqueIdentifier: { DataType=SqlDataType.UniqueIdentifier; } break;
                case SqlDataTypeOption.Date            : { DataType=SqlDataType.Date;             } break;
                case SqlDataTypeOption.Time            : { DataType=SqlDataType.Time;             } break;
                case SqlDataTypeOption.DateTime2       : { DataType=SqlDataType.DateTime2;        } break;
                case SqlDataTypeOption.DateTimeOffset  : { DataType=SqlDataType.DateTimeOffset;   } break;
                case SqlDataTypeOption.Rowversion      : { DataType=SqlDataType.Rowversion;       } break;
                case SqlDataTypeOption.Json            : { DataType=SqlDataType.Json;             } break;
                case SqlDataTypeOption.Vector          : { DataType=SqlDataType.Vector;           } break;
                default:
                    throw new ArgumentOutOfRangeException();
                }
            IsMaximum = Parameters.Any(i => i.Type == SqlLiteralValueType.Max);
            return;
            }
        #endregion

        public override String ToString() {
            var r = new StringBuilder();
            if (DataType != SqlDataType.None) {
                switch (DataType) {
                    case SqlDataType.Variant:
                        r.Append("sql_variant");
                        break;
                    default:
                        r.Append(DataType.ToString().ToLowerInvariant());
                        break;
                    }
                switch (DataType) {
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
        }
    }