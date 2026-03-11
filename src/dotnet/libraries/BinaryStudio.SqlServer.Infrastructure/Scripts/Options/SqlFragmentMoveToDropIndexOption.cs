using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(MoveToDropIndexOption))]
    internal sealed class SqlScriptDomMoveToDropIndexOption : SqlScriptDomIndexOption<MoveToDropIndexOption>
        {
        #region ctor{IServiceProvider,MoveToDropIndexOption}
        public SqlScriptDomMoveToDropIndexOption(IServiceProvider context,MoveToDropIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }