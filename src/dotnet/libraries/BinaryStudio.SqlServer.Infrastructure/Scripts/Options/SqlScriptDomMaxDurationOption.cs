using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(MaxDurationOption))]
    internal sealed class SqlScriptDomMaxDurationOption : SqlScriptDomIndexOption<MaxDurationOption>
        {
        #region ctor{IServiceProvider,MaxDurationOption}
        public SqlScriptDomMaxDurationOption(IServiceProvider context,MaxDurationOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }