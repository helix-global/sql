using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptGroupingSetItem<T> : SqlScriptGroupByItem<T>
        where T : SqlGroupingSetItem
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptGroupingSetItem(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }