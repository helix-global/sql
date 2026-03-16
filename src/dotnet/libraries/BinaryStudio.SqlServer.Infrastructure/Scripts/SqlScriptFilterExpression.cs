using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptFilterExpression<T> : SqlScriptCodeObject<T>
        where T : SqlFilterExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptFilterExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }