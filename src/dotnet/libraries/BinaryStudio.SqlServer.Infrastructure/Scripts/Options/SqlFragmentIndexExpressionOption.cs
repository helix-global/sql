using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(IndexExpressionOption))]
    internal class SqlFragmentIndexExpressionOption : SqlFragmentIndexOption<IndexExpressionOption>
        {
        #region ctor{IServiceProvider,IndexExpressionOption}
        public SqlFragmentIndexExpressionOption(IServiceProvider context,IndexExpressionOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }