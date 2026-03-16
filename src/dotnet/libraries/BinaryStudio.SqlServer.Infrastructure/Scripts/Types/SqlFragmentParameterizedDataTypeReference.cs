using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlFragmentParameterizedDataTypeReference<T> : SqlFragmentDataTypeReference<T>
        where T: ParameterizedDataTypeReference
        {
        #region ctor{IServiceProvider,T}
        protected SqlFragmentParameterizedDataTypeReference(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }