using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptClrClassSpecifier<T> : SqlScriptClrAssemblySpecifier<T>
        where T : SqlClrClassSpecifier
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptClrClassSpecifier(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }