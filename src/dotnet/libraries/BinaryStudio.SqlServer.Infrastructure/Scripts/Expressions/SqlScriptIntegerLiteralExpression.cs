using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [UsedImplicitly]
    [SqlScriptObject("Microsoft.SqlServer.Management.SqlParser.SqlCodeDom.SqlLiteralExpression.IntegerLiteralExpression")]
    internal sealed class SqlScriptIntegerLiteralExpression : SqlScriptLiteralExpression
        {
        public new Int32 Value { get; }

        #region ctor{IServiceProvider,SqlLiteralExpression}
        public SqlScriptIntegerLiteralExpression(IServiceProvider context,SqlLiteralExpression source)
            : base(context,source)
            {
            Value = PropSI4(base.Value,0);
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"(({Value}))";
            }
        #endregion
        }
    }