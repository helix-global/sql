using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptVariableAssignment<T> : SqlScriptAssignment<T>
        where T : SqlVariableAssignment
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptVariableAssignment(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }