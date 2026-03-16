using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptDmlSpecification<T> : SqlScriptCodeObject<T>
        where T : SqlDmlSpecification
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptDmlSpecification(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }