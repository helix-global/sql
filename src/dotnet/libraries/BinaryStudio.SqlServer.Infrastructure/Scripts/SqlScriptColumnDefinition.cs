using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptColumnDefinition<T> : SqlScriptCodeObject<T>
        where T: SqlColumnDefinition
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptColumnDefinition(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }