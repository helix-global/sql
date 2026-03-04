using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptCreateLoginStatement<T> : SqlScriptDdlStatement<T>
        where T : SqlCreateLoginStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptCreateLoginStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }