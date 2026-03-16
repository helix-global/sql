using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptUdtInstanceMemberExpression<T> : SqlScriptUdtMemberExpression<T>
        where T : SqlUdtInstanceMemberExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptUdtInstanceMemberExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }