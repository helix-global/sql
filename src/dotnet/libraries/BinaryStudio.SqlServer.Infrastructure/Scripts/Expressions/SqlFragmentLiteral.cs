using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlFragmentLiteral<T> : SqlFragmentValueExpression<T>,ISqlLiteralExpression
        where T: Literal
        {
        public SqlLiteralValueType Type { get; }
        [UsedImplicitly][Field] public String Value { get; }

        #region ctor{IServiceProvider,T}
        protected SqlFragmentLiteral(IServiceProvider context,T source)
            : base(context,source)
            {
            switch (source.LiteralType) {
                case LiteralType.Integer   : { Type=SqlLiteralValueType.Integer;    } break;
                case LiteralType.Real      : { Type=SqlLiteralValueType.Real;       } break;
                case LiteralType.Money     : { Type=SqlLiteralValueType.Money;      } break;
                case LiteralType.Binary    : { Type=SqlLiteralValueType.Binary;     } break;
                case LiteralType.String    : { Type=SqlLiteralValueType.String;     } break;
                case LiteralType.Null      : { Type=SqlLiteralValueType.Null;       } break;
                case LiteralType.Default   : { Type=SqlLiteralValueType.Default;    } break;
                case LiteralType.Max       : { Type=SqlLiteralValueType.Max;        } break;
                case LiteralType.Odbc      : { Type=SqlLiteralValueType.ODBC;       } break;
                case LiteralType.Identifier: { Type=SqlLiteralValueType.Identifier; } break;
                case LiteralType.Numeric   : { Type=SqlLiteralValueType.Numeric;    } break;
                default:
                    throw new ArgumentOutOfRangeException();
                }
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Type.ToString();
            }
        #endregion
        }
    }