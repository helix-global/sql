using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SetStatisticsStatement))]
    internal class SqlFragmentSetStatisticsStatement : SqlFragmentSetOnOffStatement<SetStatisticsStatement>
        {
        #region ctor{IServiceProvider,SetStatisticsStatement}
        public SqlFragmentSetStatisticsStatement(IServiceProvider context,SetStatisticsStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }