using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptFunctionDefinition<T> : SqlScriptCodeObject<T>
        where T : SqlFunctionDefinition
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptFunctionDefinition(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }