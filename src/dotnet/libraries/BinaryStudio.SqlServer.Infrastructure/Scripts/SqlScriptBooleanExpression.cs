using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptBooleanExpression<T> : SqlScriptCodeObject<T>
        where T : SqlBooleanExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptBooleanExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }