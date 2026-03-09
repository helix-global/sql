using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(IgnoreDupKeyIndexOption))]
    internal sealed class SqlScriptDomIgnoreDupKeyIndexOption : SqlScriptDomIndexStateOption<IgnoreDupKeyIndexOption>
        {
        #region ctor{IServiceProvider,IgnoreDupKeyIndexOption}
        public SqlScriptDomIgnoreDupKeyIndexOption(IServiceProvider context,IgnoreDupKeyIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }