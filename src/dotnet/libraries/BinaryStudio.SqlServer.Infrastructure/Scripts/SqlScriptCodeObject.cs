using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlScriptCodeObject<T> : SqlModelObject
        where T: SqlCodeObject
        {
        protected T Source { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptCodeObject(IServiceProvider context,T source)
            :base(context)
            {
            Source = source;
            }
        #endregion
        }
    }