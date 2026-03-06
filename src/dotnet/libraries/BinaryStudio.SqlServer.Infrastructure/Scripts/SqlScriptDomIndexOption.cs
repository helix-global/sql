using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptDomIndexOption<T> : SqlScriptDomObject<T>,ISqlScriptIndexOption
        where T: IndexOption
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptDomIndexOption(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }