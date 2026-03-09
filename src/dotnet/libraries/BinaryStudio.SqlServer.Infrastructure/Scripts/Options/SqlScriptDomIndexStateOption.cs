using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptDomIndexStateOption<T> : SqlScriptDomIndexOption<T>
        where T : IndexStateOption
        {
        #region ctor{IServiceProvider,T}
        public SqlScriptDomIndexStateOption(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject(typeof(IndexStateOption))]
    internal sealed class SqlScriptDomIndexStateOption : SqlScriptDomIndexStateOption<IndexStateOption>
        {
        #region ctor{IServiceProvider,IndexStateOption}
        public SqlScriptDomIndexStateOption(IServiceProvider context,IndexStateOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }