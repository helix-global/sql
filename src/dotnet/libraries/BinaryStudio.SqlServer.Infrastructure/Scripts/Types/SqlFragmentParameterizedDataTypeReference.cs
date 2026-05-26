using System;
using System.Collections.Generic;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class SqlFragmentParameterizedDataTypeReference<T> : SqlFragmentDataTypeReference<T>
        where T: ParameterizedDataTypeReference
        {
        [UsedImplicitly][Field] public IList<ISqlLiteralExpression> Parameters { get; }

        #region ctor{IServiceProvider,T}
        protected SqlFragmentParameterizedDataTypeReference(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }