using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptBooleanExpression<T> : SqlScriptCodeObject<T>,ISqlScriptBooleanExpression
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