using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptUpdateDeleteSpecificationBase<T> : SqlScriptDmlSpecification<T>
        where T : SqlUpdateDeleteSpecificationBase
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptUpdateDeleteSpecificationBase(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }