using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptInsertMergeActionSource<T> : SqlScriptCodeObject<T>
        where T : SqlInsertMergeActionSource
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptInsertMergeActionSource(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }