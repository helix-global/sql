using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptConditionalStatement<T> : SqlScriptStatement<T>
        where T: SqlConditionalStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptConditionalStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }