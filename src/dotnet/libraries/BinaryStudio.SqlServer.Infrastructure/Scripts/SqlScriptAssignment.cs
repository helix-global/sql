using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptAssignment<T> : SqlScriptCodeObject<T>
        where T : SqlAssignment
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptAssignment(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }