using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptTableExpression<T> : SqlScriptCodeObject<T>
        where T: SqlTableExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptTableExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }