using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptGroupByItem<T> : SqlScriptCodeObject<T>
        where T : SqlGroupByItem
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptGroupByItem(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }