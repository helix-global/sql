using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(IndexExpressionOption))]
    internal class SqlScriptDomIndexExpressionOption : SqlScriptDomIndexOption<IndexExpressionOption>
        {
        #region ctor{IServiceProvider,IndexExpressionOption}
        public SqlScriptDomIndexExpressionOption(IServiceProvider context,IndexExpressionOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }