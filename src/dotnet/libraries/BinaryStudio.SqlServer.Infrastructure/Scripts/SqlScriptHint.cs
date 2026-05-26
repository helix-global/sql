using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptHint<T> : SqlScriptCodeObject<T>
        where T : SqlHint
        {
        public Boolean IsIndexHint {get{ return Source.IsIndexHint; }}
        public Boolean IsTableHint {get{ return Source.IsTableHint; }}

        #region ctor{IServiceProvider,T}
        protected SqlScriptHint(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }