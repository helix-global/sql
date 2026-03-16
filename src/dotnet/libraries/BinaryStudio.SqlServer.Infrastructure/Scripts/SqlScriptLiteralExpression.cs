using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlLiteralExpression))]
    internal sealed class SqlScriptLiteralExpression : SqlScriptScalarExpression<SqlLiteralExpression>,ISqlLiteralExpression
        {
        [UsedImplicitly][Field] public SqlLiteralValueType Type { get; }
        [UsedImplicitly][Field] public String Value { get; }

        #region ctor{IServiceProvider,SqlLiteralExpression}
        public SqlScriptLiteralExpression(IServiceProvider context,SqlLiteralExpression source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Value;
            }
        #endregion
        }
    }