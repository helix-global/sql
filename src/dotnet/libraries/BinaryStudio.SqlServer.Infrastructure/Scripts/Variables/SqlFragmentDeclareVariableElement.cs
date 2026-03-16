using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlFragmentDeclareVariableElement<T> : SqlFragmentObject<T>
        where T: DeclareVariableElement
        {
        [UsedImplicitly][Field] public SqlIdentifier VariableName { get; }
        [UsedImplicitly][Field] public ISqlFragmentDataTypeReference DataType { get; }
        [UsedImplicitly][Field] public SqlFragmentNullableConstraintDefinition Nullable { get; }
        [UsedImplicitly][Field] public ISqlScriptScalarExpression Value { get; }

        #region ctor{IServiceProvider,T}
        protected SqlFragmentDeclareVariableElement(IServiceProvider context,T source)
            : base(context,source)
            {
            return;
            }
        #endregion
        }

    [SqlScriptObject(typeof(DeclareVariableElement))]
    internal sealed class SqlFragmentDeclareVariableElement : SqlFragmentDeclareVariableElement<DeclareVariableElement>
        {
        #region ctor{IServiceProvider,DeclareVariableElement}
        public SqlFragmentDeclareVariableElement(IServiceProvider context,DeclareVariableElement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }