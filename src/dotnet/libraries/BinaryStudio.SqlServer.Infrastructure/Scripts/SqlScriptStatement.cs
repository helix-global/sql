using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptStatement<T> : SqlScriptCodeObject<T>
        where T : SqlStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }