using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptForClause<T> : SqlScriptCodeObject<T>
        where T : SqlForClause
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptForClause(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }