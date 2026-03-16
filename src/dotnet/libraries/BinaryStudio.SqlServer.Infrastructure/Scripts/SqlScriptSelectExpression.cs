using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptSelectExpression<T> : SqlScriptCodeObject<T>
        where T : SqlSelectExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptSelectExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }