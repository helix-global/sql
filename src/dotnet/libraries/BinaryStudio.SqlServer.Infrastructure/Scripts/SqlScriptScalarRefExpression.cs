using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptScalarRefExpression<T> : SqlScriptScalarExpression<T>
        where T : SqlScalarRefExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptScalarRefExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }