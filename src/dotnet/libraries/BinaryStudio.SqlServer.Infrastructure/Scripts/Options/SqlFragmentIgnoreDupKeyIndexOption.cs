using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(IgnoreDupKeyIndexOption))]
    internal sealed class SqlFragmentIgnoreDupKeyIndexOption : SqlFragmentIndexStateOption<IgnoreDupKeyIndexOption>
        {
        #region ctor{IServiceProvider,IgnoreDupKeyIndexOption}
        public SqlFragmentIgnoreDupKeyIndexOption(IServiceProvider context,IgnoreDupKeyIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }