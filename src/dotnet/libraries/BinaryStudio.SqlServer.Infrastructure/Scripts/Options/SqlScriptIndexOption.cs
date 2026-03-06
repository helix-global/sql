using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlScriptIndexOption<T> : SqlScriptCodeObject<T>,ISqlScriptIndexOption
        where T : SqlIndexOption
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptIndexOption(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }