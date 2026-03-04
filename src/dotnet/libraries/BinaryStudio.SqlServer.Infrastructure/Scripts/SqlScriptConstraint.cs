using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptConstraint<T> : SqlScriptCodeObject<T>
        where T : SqlConstraint
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptConstraint(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }