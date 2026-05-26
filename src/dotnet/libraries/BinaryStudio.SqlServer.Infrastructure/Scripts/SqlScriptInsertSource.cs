using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptInsertSource<T> : SqlScriptCodeObject<T>
        where T : SqlInsertSource
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptInsertSource(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }