using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptInBooleanExpressionValue<T> : SqlScriptCodeObject<T>
        where T : SqlInBooleanExpressionValue
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptInBooleanExpressionValue(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }