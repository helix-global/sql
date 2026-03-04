using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptLiteralExpression : SqlScriptScalarExpression<SqlLiteralExpression>
        {
        public LiteralValueType Type {get{ return Source.Type; }}
        public String Value { get { return Source.Value; }}

        #region ctor{IServiceProvider,SqlLiteralExpression}
        public SqlScriptLiteralExpression(IServiceProvider context,SqlLiteralExpression source)
            : base(context,source)
            {
            }
        #endregion

        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Value;
            }
        }
    }