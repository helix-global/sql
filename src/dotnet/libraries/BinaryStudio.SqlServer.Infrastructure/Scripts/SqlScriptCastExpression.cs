using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptCastExpression<T> : SqlScriptBuiltinScalarFunctionCallExpression<T>
        where T : SqlCastExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptCastExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }