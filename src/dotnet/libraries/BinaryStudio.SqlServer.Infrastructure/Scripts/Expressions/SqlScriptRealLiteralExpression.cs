using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject("Microsoft.SqlServer.Management.SqlParser.SqlCodeDom.SqlLiteralExpression.RealLiteralExpression")]
    internal sealed class SqlScriptRealLiteralExpression : SqlScriptLiteralExpression
        {
        #region ctor{IServiceProvider,SqlLiteralExpression}
        public SqlScriptRealLiteralExpression(IServiceProvider context,SqlLiteralExpression source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return base.ToString();
            }
        #endregion
        }
    }